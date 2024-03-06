import 'package:flutter/material.dart';
import '../elements/flow_element.dart';
import 'element_text_widget.dart';

/// A kind of element
class HexagonWidget extends StatelessWidget {
  final FlowElement element;

  const HexagonWidget({
    super.key,
    required this.element,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: element.size.width,
      height: element.size.height,
      child: Stack(
        children: [
          CustomPaint(
            size: element.size,
            painter: _HexagonPainter(
              element: element,
            ),
          ),
          ElementTextWidget(element: element),
        ],
      ),
    );
  }
}

class _HexagonPainter extends CustomPainter {
  final FlowElement element;

  _HexagonPainter({
    required this.element,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();
    final Path path = Path();

    paint.style = PaintingStyle.fill;
    paint.color = element.backgroundColor;

    path.moveTo(0, size.height / 2);
    path.lineTo(size.width / 4, size.height);
    path.lineTo(size.width * 3 / 4, size.height);
    path.lineTo(size.width, size.height / 2);
    path.lineTo(size.width * 3 / 4, 0);
    path.lineTo(size.width / 4, 0);
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
