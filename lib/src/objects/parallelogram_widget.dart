import 'package:flutter/material.dart';

import '../elements/flow_element.dart';
import 'element_text_widget.dart';

/// A kind of element
class ParallelogramWidget extends StatelessWidget {
  final FlowElement element;

  const ParallelogramWidget({
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
            painter: _ParallelogramPainter(
              element: element,
            ),
          ),
          ElementTextWidget(element: element),
        ],
      ),
    );
  }
}

class _ParallelogramPainter extends CustomPainter {
  final FlowElement element;

  _ParallelogramPainter({
    required this.element,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();
    final Path path = Path();

    paint.style = PaintingStyle.fill;
    paint.color = element.backgroundColor;

    path.moveTo(size.width / 8, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width - size.width / 8, size.height);
    path.lineTo(0, size.height);
    path.close();
    if (element.elevation > 0.01) {
      canvas.drawShadow(
        path.shift(Offset(element.elevation, element.elevation)),
        Colors.black,
        element.elevation,
        true,
      );
    }
    canvas.drawPath(path, paint);

    paint.strokeWidth = element.borderThickness;
    paint.color = element.borderColor;
    paint.style = PaintingStyle.stroke;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
