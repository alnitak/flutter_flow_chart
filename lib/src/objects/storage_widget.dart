import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_flow_chart/src/elements/flow_element.dart';
import 'package:flutter_flow_chart/src/objects/element_text_widget.dart';

/// A kind of element
class StorageWidget extends StatelessWidget {
  ///
  const StorageWidget({
    required this.element,
    super.key,
  });

  ///
  final FlowElement element;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: element.size.width,
      height: element.size.height,
      child: Stack(
        children: [
          CustomPaint(
            size: element.size,
            painter: _StoragePainter(
              element: element,
            ),
          ),
          ElementTextWidget(element: element),
        ],
      ),
    );
  }
}

class _StoragePainter extends CustomPainter {
  _StoragePainter({
    required this.element,
  });

  final FlowElement element;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final path = Path();
    final path2 = Path();

    paint
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.fill
      ..color = element.backgroundColor;

    path2
      ..moveTo(size.width, size.height / 4.0 / 2.0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..lineTo(0, size.height / 4.0 / 2.0)

      // oval
      ..addArc(Rect.fromLTWH(0, 0, size.width, size.height / 4.0), pi, pi)
      ..addArc(Rect.fromLTWH(0, 0, size.width, size.height / 4.0), 0, pi)
      ..addArc(Rect.fromLTWH(0, 4, size.width, size.height / 4.0 + 4), 0, pi);

    if (element.elevation > 0.01) {
      canvas.drawShadow(
        path2.shift(Offset(element.elevation, element.elevation)),
        Colors.black,
        element.elevation,
        true,
      );
    }
    canvas.drawPath(path2, paint);

    paint
      ..strokeWidth = element.borderThickness
      ..color = element.borderColor
      ..style = PaintingStyle.stroke;

    canvas
      ..drawPath(path, paint)
      ..drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
