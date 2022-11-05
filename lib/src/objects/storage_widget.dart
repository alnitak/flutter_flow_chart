import 'dart:math';

import 'package:flutter/material.dart';

import '../elements/flow_element.dart';
import 'element_text_widget.dart';

/// A kind of element
class StorageWidget extends StatelessWidget {
  final FlowElement element;

  const StorageWidget({
    Key? key,
    required this.element,
  }) : super(key: key);

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
  final FlowElement element;

  _StoragePainter({
    required this.element,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();
    Path path = Path();
    Path path2 = Path();

    paint.strokeJoin = StrokeJoin.round;

    paint.style = PaintingStyle.fill;
    paint.color = element.backgroundColor;

    path2.moveTo(size.width, size.height / 4.0 / 2.0);
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.lineTo(0, size.height / 4.0 / 2.0);
    // oval
    path2.addArc(Rect.fromLTWH(0, 0, size.width, size.height / 4.0), pi, pi);
    path2.addArc(Rect.fromLTWH(0, 0, size.width, size.height / 4.0), 0, pi);
    path2.addArc(Rect.fromLTWH(0, 4, size.width, size.height / 4.0 + 4), 0, pi);

    if (element.elevation > 0.01) {
      canvas.drawShadow(
        path2.shift(Offset(element.elevation, element.elevation)),
        Colors.black,
        element.elevation,
        true,
      );
    }
    canvas.drawPath(path2, paint);

    paint.strokeWidth = element.borderThickness;
    paint.color = element.borderColor;
    paint.style = PaintingStyle.stroke;
    canvas.drawPath(path, paint);
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
