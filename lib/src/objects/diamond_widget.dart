import 'package:flutter/material.dart';

import '../elements/flow_element.dart';
import 'element_text_widget.dart';

/// A kind of element
class DiamondWidget extends StatelessWidget {
  final FlowElement element;

  const DiamondWidget({
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
            painter: _DiamondPainter(
              element: element,
            ),
          ),
          ElementTextWidget(element: element),
        ],
      ),
    );
  }
}

class _DiamondPainter extends CustomPainter {
  final FlowElement element;

  _DiamondPainter({
    required this.element,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();
    Path path = Path();

    paint.strokeJoin = StrokeJoin.round;

    paint.style = PaintingStyle.fill;
    paint.color = element.backgroundColor;
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height / 2);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(0, size.height / 2);
    path.close();
    print(element.elevation);
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
