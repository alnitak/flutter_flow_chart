import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_flow_chart/flutter_flow_chart.dart';
import 'package:flutter_flow_chart/src/ui/segment_handler.dart';

/// Arrow style enumeration
enum ArrowStyle {
  /// A curved arrow which points nicely to each handlers
  curve,

  /// A segmented line where pivot points can be added and curvature between
  /// them can be adjusted with a tension.
  segmented,

  /// A rectangular shaped line.
  rectangular,
}

/// Arrow parameters used by [DrawArrow] widget
class ArrowParams extends ChangeNotifier {
  ///
  ArrowParams({
    this.thickness = 1.7,
    this.headRadius = 6,
    double tailLength = 25.0,
    this.color = Colors.black,
    this.style,
    this.tension = 1.0,
    this.startArrowPosition = Alignment.centerRight,
    this.endArrowPosition = Alignment.centerLeft,
  }) : _tailLength = tailLength;

  ///
  factory ArrowParams.fromMap(Map<String, dynamic> map) {
    return ArrowParams(
      thickness: (map['thickness'] as num).toDouble(),
      headRadius: (map['headRadius'] as num).toDouble() ?? 6.0,
      tailLength: (map['tailLength'] as num).toDouble() ?? 25.0,
      color: Color(map['color'] as int),
      style: ArrowStyle.values[map['style'] as int? ?? 0],
      tension: (map['tension'] as num).toDouble() ?? 1,
      startArrowPosition: Alignment(
        (map['startArrowPositionX'] as num).toDouble(),
        (map['startArrowPositionY'] as num).toDouble(),
      ),
      endArrowPosition: Alignment(
        (map['endArrowPositionX'] as num).toDouble(),
        (map['endArrowPositionY'] as num).toDouble(),
      ),
    );
  }

  ///
  factory ArrowParams.fromJson(String source) =>
      ArrowParams.fromMap(json.decode(source) as Map<String, dynamic>);

  /// Arrow thickness.
  double thickness;

  /// The radius of arrow tip.
  double headRadius;

  /// Arrow color.
  final Color color;

  /// The start position alignment.
  final Alignment startArrowPosition;

  /// The end position alignment.
  final Alignment endArrowPosition;

  /// The tail length of the arrow.
  double _tailLength;

  /// The style of the arrow.
  ArrowStyle? style;

  /// The curve tension for pivot points when using [ArrowStyle.segmented].
  /// 0 means no curve on segments.
  double tension;

  ///
  ArrowParams copyWith({
    double? thickness,
    Color? color,
    ArrowStyle? style,
    double? tension,
    Alignment? startArrowPosition,
    Alignment? endArrowPosition,
  }) {
    return ArrowParams(
      thickness: thickness ?? this.thickness,
      color: color ?? this.color,
      style: style ?? this.style,
      tension: tension ?? this.tension,
      startArrowPosition: startArrowPosition ?? this.startArrowPosition,
      endArrowPosition: endArrowPosition ?? this.endArrowPosition,
    );
  }

  ///
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'thickness': thickness,
      'headRadius': headRadius,
      'tailLength': _tailLength,
      'color': color.value,
      'style': style?.index,
      'tension': tension,
      'startArrowPositionX': startArrowPosition.x,
      'startArrowPositionY': startArrowPosition.y,
      'endArrowPositionX': endArrowPosition.x,
      'endArrowPositionY': endArrowPosition.y,
    };
  }

  ///
  String toJson() => json.encode(toMap());

  ///
  void setScale(double currentZoom, double factor) {
    thickness = thickness / currentZoom * factor;
    headRadius = headRadius / currentZoom * factor;
    _tailLength = _tailLength / currentZoom * factor;
    notifyListeners();
  }

  ///
  double get tailLength => _tailLength;
}

/// Notifier to update arrows position, starting/ending points and params
class DrawingArrow extends ChangeNotifier {
  DrawingArrow._();

  /// Singleton instance of this.
  static final instance = DrawingArrow._();

  /// Arrow parameters.
  ArrowParams params = ArrowParams();

  /// Sets the parameters.
  void setParams(ArrowParams params) {
    this.params = params;
    notifyListeners();
  }

  /// Starting arrow offset.
  Offset from = Offset.zero;

  ///
  void setFrom(Offset from) {
    this.from = from;
    notifyListeners();
  }

  /// Ending arrow offset.
  Offset to = Offset.zero;

  ///
  void setTo(Offset to) {
    this.to = to;
    notifyListeners();
  }

  ///
  bool isZero() {
    return from == Offset.zero && to == Offset.zero;
  }

  ///
  void reset() {
    params = ArrowParams();
    from = Offset.zero;
    to = Offset.zero;
    notifyListeners();
  }
}

/// Draw arrow from [srcElement] to [destElement]
/// using [arrowParams] parameters
class DrawArrow extends StatefulWidget {
  ///
  DrawArrow({
    required this.srcElement,
    required this.destElement,
    required List<Pivot> pivots,
    super.key,
    ArrowParams? arrowParams,
  })  : arrowParams = arrowParams ?? ArrowParams(),
        pivots = PivotsNotifier(pivots);

  ///
  final ArrowParams arrowParams;

  ///
  final FlowElement srcElement;

  ///
  final FlowElement destElement;

  ///
  final PivotsNotifier pivots;

  @override
  State<DrawArrow> createState() => _DrawArrowState();
}

class _DrawArrowState extends State<DrawArrow> {
  @override
  void initState() {
    super.initState();
    widget.srcElement.addListener(_elementChanged);
    widget.destElement.addListener(_elementChanged);
    widget.pivots.addListener(_elementChanged);
  }

  @override
  void dispose() {
    widget.srcElement.removeListener(_elementChanged);
    widget.destElement.removeListener(_elementChanged);
    widget.pivots.removeListener(_elementChanged);
    super.dispose();
  }

  void _elementChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var from = Offset.zero;
    var to = Offset.zero;

    from = Offset(
      widget.srcElement.position.dx +
          widget.srcElement.handlerSize / 2.0 +
          (widget.srcElement.size.width *
              ((widget.arrowParams.startArrowPosition.x + 1) / 2)),
      widget.srcElement.position.dy +
          widget.srcElement.handlerSize / 2.0 +
          (widget.srcElement.size.height *
              ((widget.arrowParams.startArrowPosition.y + 1) / 2)),
    );
    to = Offset(
      widget.destElement.position.dx +
          widget.destElement.handlerSize / 2.0 +
          (widget.destElement.size.width *
              ((widget.arrowParams.endArrowPosition.x + 1) / 2)),
      widget.destElement.position.dy +
          widget.destElement.handlerSize / 2.0 +
          (widget.destElement.size.height *
              ((widget.arrowParams.endArrowPosition.y + 1) / 2)),
    );

    return RepaintBoundary(
      child: Builder(
        builder: (context) {
          return CustomPaint(
            painter: ArrowPainter(
              params: widget.arrowParams,
              from: from,
              to: to,
              pivots: widget.pivots.value,
            ),
            child: Container(),
          );
        },
      ),
    );
  }
}

/// Paint the arrow connection taking in count the
/// [ArrowParams.startArrowPosition] and
/// [ArrowParams.endArrowPosition] alignment.
class ArrowPainter extends CustomPainter {
  ///
  ArrowPainter({
    required this.params,
    required this.from,
    required this.to,
    List<Pivot>? pivots,
  }) : pivots = pivots ?? [];

  ///
  final ArrowParams params;

  ///
  final Offset from;

  ///
  final Offset to;

  ///
  final Path path = Path();

  ///
  final List<List<Offset>> lines = [];

  ///
  final List<Pivot> pivots;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..strokeWidth = params.thickness;

    if (params.style == ArrowStyle.curve) {
      drawCurve(canvas, paint);
    } else if (params.style == ArrowStyle.segmented) {
      drawLine();
    } else if (params.style == ArrowStyle.rectangular) {
      drawRectangularLine(canvas, paint);
    }

    canvas.drawCircle(to, params.headRadius, paint);

    paint
      ..color = params.color
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, paint);
  }

  /// Draw a segmented line with a tension between points.
  void drawLine() {
    final points = [from];
    for (final pivot in pivots) {
      points.add(pivot.pivot);
    }
    points.add(to);

    path.moveTo(points.first.dx, points.first.dy);

    for (var i = 0; i < points.length - 1; i++) {
      final p0 = (i > 0) ? points[i - 1] : points[0];
      final p1 = points[i];
      final p2 = points[i + 1];
      final p3 = (i != points.length - 2) ? points[i + 2] : p2;

      final cp1x = p1.dx + (p2.dx - p0.dx) / 6 * params.tension;
      final cp1y = p1.dy + (p2.dy - p0.dy) / 6 * params.tension;

      final cp2x = p2.dx - (p3.dx - p1.dx) / 6 * params.tension;
      final cp2y = p2.dy - (p3.dy - p1.dy) / 6 * params.tension;

      path.cubicTo(cp1x, cp1y, cp2x, cp2y, p2.dx, p2.dy);
    }
  }

  /// Draw a rectangular line
  void drawRectangularLine(Canvas canvas, Paint paint) {
    // calculating offsetted pivot
    var pivot1 = Offset(from.dx, from.dy);
    if (params.startArrowPosition.y == 1) {
      pivot1 = Offset(from.dx, from.dy + params.tailLength);
    } else if (params.startArrowPosition.y == -1) {
      pivot1 = Offset(from.dx, from.dy - params.tailLength);
    }

    final pivot2 = Offset(to.dx, pivot1.dy);

    path
      ..moveTo(from.dx, from.dy)
      ..lineTo(pivot1.dx, pivot1.dy)
      ..lineTo(pivot2.dx, pivot2.dy)
      ..lineTo(to.dx, to.dy);

    lines.addAll([
      [from, pivot2],
      [pivot2, to],
    ]);
  }

  /// Draws a curve starting/ending the handler linearly from the center
  /// of the element.
  void drawCurve(Canvas canvas, Paint paint) {
    var distance = 0.0;

    var dx = 0.0;
    var dy = 0.0;

    final p0 = Offset(from.dx, from.dy);
    final p4 = Offset(to.dx, to.dy);
    distance = (p4 - p0).distance / 3;

    // checks for the arrow direction
    if (params.startArrowPosition.x > 0) {
      dx = distance;
    } else if (params.startArrowPosition.x < 0) {
      dx = -distance;
    }
    if (params.startArrowPosition.y > 0) {
      dy = distance;
    } else if (params.startArrowPosition.y < 0) {
      dy = -distance;
    }
    final p1 = Offset(from.dx + dx, from.dy + dy);
    dx = 0;
    dy = 0;

    // checks for the arrow direction
    if (params.endArrowPosition.x > 0) {
      dx = distance;
    } else if (params.endArrowPosition.x < 0) {
      dx = -distance;
    }
    if (params.endArrowPosition.y > 0) {
      dy = distance;
    } else if (params.endArrowPosition.y < 0) {
      dy = -distance;
    }
    final p3 = params.endArrowPosition == Alignment.center
        ? Offset(to.dx, to.dy)
        : Offset(to.dx + dx, to.dy + dy);
    final p2 = Offset(
      p1.dx + (p3.dx - p1.dx) / 2,
      p1.dy + (p3.dy - p1.dy) / 2,
    );

    path
      ..moveTo(p0.dx, p0.dy)
      ..conicTo(p1.dx, p1.dy, p2.dx, p2.dy, 1)
      ..conicTo(p3.dx, p3.dy, p4.dx, p4.dy, 1);
  }

  @override
  bool shouldRepaint(ArrowPainter oldDelegate) {
    return true;
  }

  @override
  bool? hitTest(Offset position) => false;
}

/// Notifier for pivot points.
class PivotsNotifier extends ValueNotifier<List<Pivot>> {
  ///
  PivotsNotifier(super.value) {
    for (final pivot in value) {
      pivot.addListener(notifyListeners);
    }
  }

  /// Add a pivot point.
  void add(Pivot pivot) {
    value.add(pivot);
    pivot.addListener(notifyListeners);
    notifyListeners();
  }

  /// Remove a pivot point.
  void remove(Pivot pivot) {
    value.remove(pivot);
    pivot.removeListener(notifyListeners);
    notifyListeners();
  }

  /// Insert a pivot point.
  void insert(int index, Pivot pivot) {
    value.insert(index, pivot);
    pivot.addListener(notifyListeners);
    notifyListeners();
  }

  /// Remove a pivot point by its index.
  void removeAt(int index) {
    value.removeAt(index).removeListener(notifyListeners);
    notifyListeners();
  }
}
