import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_flow_chart/flutter_flow_chart.dart';

/// Arrow parameters used by [DrawArrow] widget
class ArrowParams extends ChangeNotifier {
  /// Arrow thickness
  double thickness;

  double headRadius;

  /// Arrow color
  final Color color;

  /// The start position alignment
  final Alignment startArrowPosition;

  /// The end position alignment
  final Alignment endArrowPosition;

  ArrowParams({
    this.thickness = 1.7,
    this.headRadius = 6,
    this.color = Colors.black,
    this.startArrowPosition = Alignment.centerRight,
    this.endArrowPosition = Alignment.centerLeft,
  });

  ArrowParams copyWith({
    double? thickness,
    Color? color,
    Alignment? startArrowPosition,
    Alignment? endArrowPosition,
  }) {
    return ArrowParams(
      thickness: thickness ?? this.thickness,
      color: color ?? this.color,
      startArrowPosition: startArrowPosition ?? this.startArrowPosition,
      endArrowPosition: endArrowPosition ?? this.endArrowPosition,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'thickness': thickness,
      'color': color.value,
      'startArrowPositionX': startArrowPosition.x,
      'startArrowPositionY': startArrowPosition.y,
      'endArrowPositionX': endArrowPosition.x,
      'endArrowPositionY': endArrowPosition.y,
    };
  }

  factory ArrowParams.fromMap(Map<String, dynamic> map) {
    return ArrowParams(
      thickness: map['thickness'].toDouble(),
      color: Color(map['color'] as int),
      startArrowPosition: Alignment(
        map['startArrowPositionX'].toDouble(),
        map['startArrowPositionY'].toDouble(),
      ),
      endArrowPosition: Alignment(
        map['endArrowPositionX'].toDouble(),
        map['endArrowPositionY'].toDouble(),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory ArrowParams.fromJson(String source) =>
      ArrowParams.fromMap(json.decode(source) as Map<String, dynamic>);

  void setScale(double curretnZoom, double factor) {
    thickness = thickness / curretnZoom * factor;
    headRadius = headRadius / curretnZoom * factor;
    notifyListeners();
  }
}

/// Notifier to update arrows position, starting/ending points and params
class DrawingArrow extends ChangeNotifier {
  DrawingArrow._();
  static final instance = DrawingArrow._();

  ArrowParams params = ArrowParams();
  setParams(ArrowParams params) {
    this.params = params;
    notifyListeners();
  }

  Offset from = Offset.zero;
  setFrom(Offset from) {
    this.from = from;
    notifyListeners();
  }

  Offset to = Offset.zero;
  setTo(Offset to) {
    this.to = to;
    notifyListeners();
  }

  bool isZero() {
    return from == Offset.zero && to == Offset.zero;
  }

  reset() {
    params = ArrowParams();
    from = Offset.zero;
    to = Offset.zero;
    notifyListeners();
  }
}

/// Draw arrow from [srcElement] to [destElement]
/// using [arrowParams] parameters
class DrawArrow extends StatefulWidget {
  final ArrowParams arrowParams;
  final FlowElement srcElement;
  final FlowElement destElement;
  final Function(
    BuildContext context,
    Offset clickPosition,
    FlowElement srcElement,
    FlowElement destElement,
  )? onTap;
  final Function(
    BuildContext context,
    Offset clickPosition,
    FlowElement srcElement,
    FlowElement destElement,
  )? onLongPress;
  final Function(
    BuildContext context,
    Offset clickPosition,
    FlowElement srcElement,
    FlowElement destElement,
  )? onSecondaryTap;
  final Function(
    BuildContext context,
    Offset clickPosition,
    FlowElement srcElement,
    FlowElement destElement,
  )? onSecondaryLongPress;

  DrawArrow({
    super.key,
    ArrowParams? arrowParams,
    required this.srcElement,
    required this.destElement,
    this.onTap,
    this.onLongPress,
    this.onSecondaryTap,
    this.onSecondaryLongPress,
  }) : arrowParams = arrowParams ?? ArrowParams();

  @override
  State<DrawArrow> createState() => _DrawArrowState();
}

class _DrawArrowState extends State<DrawArrow> {
  @override
  void initState() {
    super.initState();
    widget.srcElement.addListener(_elementChanged);
    widget.destElement.addListener(_elementChanged);
  }

  @override
  void dispose() {
    widget.srcElement.removeListener(_elementChanged);
    widget.destElement.removeListener(_elementChanged);
    super.dispose();
  }

  _elementChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Offset from = Offset(
      widget.srcElement.position.dx +
          widget.srcElement.handlerSize / 2.0 +
          (widget.srcElement.size.width *
              ((widget.arrowParams.startArrowPosition.x + 1) / 2)),
      widget.srcElement.position.dy +
          widget.srcElement.handlerSize / 2.0 +
          (widget.srcElement.size.height *
              ((widget.arrowParams.startArrowPosition.y + 1) / 2)),
    );
    Offset to = Offset(
      widget.destElement.position.dx +
          widget.destElement.handlerSize / 2.0 +
          (widget.destElement.size.width *
              ((widget.arrowParams.endArrowPosition.x + 1) / 2)),
      widget.destElement.position.dy +
          widget.destElement.handlerSize / 2.0 +
          (widget.destElement.size.height *
              ((widget.arrowParams.endArrowPosition.y + 1) / 2)),
    );

    Offset tapPosition = Offset.zero;
    Offset secondaryTapPosition = Offset.zero;
    return GestureDetector(
      onTapDown: (details) => tapPosition = details.localPosition,
      onSecondaryTapDown: (details) =>
          secondaryTapPosition = details.localPosition,
      onTap: () {
        if (widget.onTap != null) {
          widget.onTap!(
            context,
            tapPosition,
            widget.srcElement,
            widget.destElement,
          );
        }
      },
      onLongPress: () {
        if (widget.onLongPress != null) {
          widget.onLongPress!(
            context,
            tapPosition,
            widget.srcElement,
            widget.destElement,
          );
        }
      },
      onSecondaryTap: () {
        if (widget.onSecondaryTap != null) {
          widget.onSecondaryTap!(
            context,
            secondaryTapPosition,
            widget.srcElement,
            widget.destElement,
          );
        }
      },
      onSecondaryLongPress: () {
        if (widget.onSecondaryLongPress != null) {
          widget.onSecondaryLongPress!(
            context,
            secondaryTapPosition,
            widget.srcElement,
            widget.destElement,
          );
        }
      },
      child: RepaintBoundary(
        child: CustomPaint(
          painter: ArrowPainter(
            params: widget.arrowParams,
            from: from,
            to: to,
          ),
          child: Container(),
        ),
      ),
    );
  }
}

/// Paint the arrow connection taking in count the
/// [params.startArrowPosition] and [params.endArrowPosition] alignment
class ArrowPainter extends CustomPainter {
  final ArrowParams params;
  final Offset from;
  final Offset to;
  final Path path = Path();

  ArrowPainter({
    required this.params,
    required this.from,
    required this.to,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();

    double distance = 0;

    double dx = 0;
    double dy = 0;

    Offset p0 = Offset(from.dx, from.dy);
    Offset p4 = Offset(to.dx, to.dy);
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
    Offset p1 = Offset(from.dx + dx, from.dy + dy);
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
    Offset p3 = params.endArrowPosition == const Alignment(0.0, 0.0)
        ? Offset(to.dx, to.dy)
        : Offset(to.dx + dx, to.dy + dy);
    Offset p2 = Offset(
      p1.dx + (p3.dx - p1.dx) / 2,
      p1.dy + (p3.dy - p1.dy) / 2,
    );

    path.moveTo(p0.dx, p0.dy);
    path.conicTo(p1.dx, p1.dy, p2.dx, p2.dy, 1.0);
    path.conicTo(p3.dx, p3.dy, p4.dx, p4.dy, 1.0);

    // canvas.drawCircle(p0, 10, paint);
    // canvas.drawCircle(p1, 9, paint);
    // canvas.drawCircle(p2, 8, paint);
    // canvas.drawCircle(p3, 7, paint);
    canvas.drawCircle(p4, params.headRadius, paint);

    paint.color = params.color;
    paint.strokeWidth = params.thickness;
    paint.style = PaintingStyle.stroke;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(ArrowPainter oldDelegate) =>
      !(from == oldDelegate.from && to == oldDelegate.to);

  @override
  bool? hitTest(Offset position) {
    return path.contains(position);
  }
}
